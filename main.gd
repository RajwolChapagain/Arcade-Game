extends Node2D

func _ready():
	$Ship.bullet_fired.connect(on_player_fired_bullet)
	$Ship2.bullet_fired.connect(on_player_fired_bullet)

func on_player_fired_bullet(bullet_scene, direction, location, bullet_layer):
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = location
	bullet.set_direction(direction) 
	bullet.set_collision_layer(bullet_layer)
	bullet.set_collision_mask(bullet_layer)
