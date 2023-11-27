extends Node2D

@export var objects = [] 

signal object_spawned(object)

func _on_timer_timeout():
	var object = objects.pick_random().instantiate()
	$Path2D/PathFollow2D.progress_ratio = randf()
	object.global_position = $Path2D/PathFollow2D.position

	var direction = $Path2D/PathFollow2D.rotation + PI / 2
	direction += randf_range(- PI / 4, PI / 4)
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	object.angular_velocity = velocity.x / 2
	object.linear_velocity = velocity.rotated(direction)
	object.rotation = direction
	add_child(object)
	object_spawned.emit(object)

func set_path_points(point1, point2, point3, point4):
	$Path2D.curve.add_point(point1)
	$Path2D.curve.add_point(point2)
	$Path2D.curve.add_point(point3)
	$Path2D.curve.add_point(point4)
	$Path2D.curve.add_point(point1)
