extends Node2D

func _ready():
	$Ship.bullet_fired.connect(on_player_fired_bullet)
	$Ship2.bullet_fired.connect(on_player_fired_bullet)
	$Ship.hit.connect(on_player1_hit)
	$Ship2.hit.connect(on_player2_hit)
	$Ship.super_percentage_changed.connect(on_player1_super_percentage_changed)	
	$Ship2.super_percentage_changed.connect(on_player2_super_percentage_changed)
	$Ship.player_died.connect(on_player1_died)
	$Ship2.player_died.connect(on_player2_died)
	
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

func on_player1_super_percentage_changed(new_super_percentage):
	$HUD.update_p1_super_bar(new_super_percentage)

func on_player2_super_percentage_changed(new_super_percentage):
	$HUD.update_p2_super_bar(new_super_percentage)

func on_player1_died():
	on_game_over("Player2")

func on_player2_died():
	on_game_over("Player1")

func on_game_over(winner):
	print(winner + " wins!")
