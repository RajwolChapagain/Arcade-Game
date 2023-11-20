extends Node2D

const RADIUS = 200
const angular_velocity = 360
var owner_player = 1

func _ready():
	var angle = 2 * PI / get_child_count()
	var distance_vector = Vector2(RADIUS, 0)
	var current_angle = 0
	
	for child in get_children():
		child.position = distance_vector.rotated(current_angle)
		child.is_in_ring = true
		current_angle += angle

func set_bullets_layer(layer):
	for child in get_children():
		child.set_collision_layer(layer)
		child.set_collision_mask(layer)
		
func _physics_process(delta):
	rotation_degrees += angular_velocity * delta
