extends Node2D

var super_boost = preload("res://powerups/super_boost.tscn")

signal powerup_spawned(power_up)

func _on_timer_timeout():
	var power_up = super_boost.instantiate()
	$Path2D/PathFollow2D.progress_ratio = randf()
	power_up.global_position = $Path2D/PathFollow2D.position

	var direction = $Path2D/PathFollow2D.rotation + PI / 2
	direction += randf_range(- PI / 4, PI / 4)
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	power_up.angular_velocity = velocity.x / 2
	power_up.linear_velocity = velocity.rotated(direction)
	add_child(power_up)
	powerup_spawned.emit(power_up)

func set_path_points(point1, point2, point3, point4):
	$Path2D.curve.add_point(point1)
	$Path2D.curve.add_point(point2)
	$Path2D.curve.add_point(point3)
	$Path2D.curve.add_point(point4)
	$Path2D.curve.add_point(point1)
