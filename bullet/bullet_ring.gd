extends Node2D

var radius = 50
const angular_velocity = 180
var owner_player = 1:
	get:
		return owner_player
	set(value):
		owner_player = value
		for child in get_children():
			child.owner_player = value

signal destroyed

func _ready():
	var angle = 2 * PI / get_child_count()
	var distance_vector = Vector2(radius, 0)
	var current_angle = 0
	
	for child in get_children():
		child.position = distance_vector.rotated(current_angle)
		child.is_in_ring = true
		current_angle += angle

func set_bullets_layer_mask(layer_mask):
	for child in get_children():
		child.set_collision_mask_value(layer_mask, true)

func set_bullets_layer(layer):
	for child in get_children():
		child.set_collision_layer_value(layer, true)
			
func _physics_process(delta):
	rotation_degrees += angular_velocity * delta
	
	if get_child_count() == 0:
		destroyed.emit()
		queue_free()
