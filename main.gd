extends Node2D

func _ready():
	$Ship.bullet_fired.connect(on_player_fired_bullet)
	$Ship2.bullet_fired.connect(on_player_fired_bullet)
	$Ship.hit.connect(on_player1_hit)
	$Ship2.hit.connect(on_player2_hit)

func on_player_fired_bullet(bullet_scene, direction, location, bullet_layer):
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	bullet.global_position = location
	bullet.set_direction(direction) 
	bullet.set_collision_layer(bullet_layer)
	bullet.set_collision_mask(bullet_layer)

func on_player1_hit(damage):
	$HUD.decrease_p1_health(damage)
	
func on_player2_hit(damage):
	$HUD.decrease_p2_health(damage)
