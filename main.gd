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
	$Ship.player_exited_screen.connect(on_player1_exited_screen)
	$Ship.player_entered_screen.connect(on_player1_entered_screen)
	$Ship2.player_exited_screen.connect(on_player2_exited_screen)
	$Ship2.player_entered_screen.connect(on_player2_entered_screen)
	
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

func on_player1_exited_screen():
	$P1OffscreenTimer.start()
	
func on_player1_entered_screen():
	$P1OffscreenTimer.stop()
	
func on_player2_exited_screen():
	$P2OffscreenTimer.start()
	
func on_player2_entered_screen():
	$P2OffscreenTimer.stop()
	
func on_player1_died():
	on_game_over("Player2")

func on_player2_died():
	on_game_over("Player1")

func on_game_over(winner):
	print(winner + " wins!")

func _on_p_1_offscreen_timer_timeout():
	$Ship.on_hit(100)

func _on_p_2_offscreen_timer_timeout():
	$Ship2.on_hit(100)
