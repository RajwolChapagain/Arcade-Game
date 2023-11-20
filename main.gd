extends Node2D

func _ready():
	$Ship.bullet_fired.connect(on_player_fired_bullet)
	$Ship2.bullet_fired.connect(on_player_fired_bullet)
	$Ship.hit.connect(on_player1_hit)
	$Ship2.hit.connect(on_player2_hit)
	$Ship.hp_changed.connect(on_player1_hp_changed)
	$Ship2.hp_changed.connect(on_player2_hp_changed)
	$Ship.super_percentage_changed.connect(on_player1_super_percentage_changed)	
	$Ship2.super_percentage_changed.connect(on_player2_super_percentage_changed)
	$Ship.player_died.connect(on_player1_died)
	$Ship2.player_died.connect(on_player2_died)
	
	var offset = 80
	$Spawner.set_path_points(Vector2(-2000 - offset, -1500 - offset), Vector2(2000 + offset, -1500 - offset), Vector2(2000 + offset, 1500 + offset), Vector2(-2000 - offset, 1500 + offset))

	randomize()
	var randX = randi_range(0, 100)
	var randY = randi_range(-1000, 1000)
	$Ship.position += Vector2(randX, randY)
	randX = randi_range(0, -1000)
	randY = randi_range(-1000, 1000)
	$Ship2.position += Vector2(randX, randY)
		
func on_player_fired_bullet(bullet_scene, direction, location, bullet_layer):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = location
	add_child(bullet)
	bullet.set_direction(direction) 
	bullet.set_collision_layer(bullet_layer)
	bullet.set_collision_mask(bullet_layer)

func on_player1_hit(damage):
	$Ship2.super_percentage += damage / 2
	
func on_player2_hit(damage):
	$Ship.super_percentage += damage / 2

func on_player1_hp_changed(new_hp):
	$HUD.set_p1_health(new_hp)

func on_player2_hp_changed(new_hp):
	$HUD.set_p2_health(new_hp)
	
func on_player1_super_percentage_changed(new_super_percentage):
	$HUD.update_p1_super_bar(new_super_percentage)

func on_player2_super_percentage_changed(new_super_percentage):
	$HUD.update_p2_super_bar(new_super_percentage)
	
func on_player1_died():
	$HUD.set_p1_health(0)
	on_game_over("Player2")

func on_player2_died():
	$HUD.set_p2_health(0)	
	on_game_over("Player1")

func on_game_over(winner):
	print(winner + " wins!")

func _on_spawner_powerup_spawned(powerup):
	if powerup.is_in_group("super_boost"):
		powerup.collected.connect(_on_super_boost_collected)
	elif powerup.is_in_group("hp_boost"):
		powerup.collected.connect(_on_hp_boost_collected)
	
func _on_super_boost_collected(player, values):
	if player == 1:
		$Ship.super_percentage += values[0]
	else:
		$Ship2.super_percentage +=  values[0]
	
func _on_hp_boost_collected(player, values):
	if player == 1:
		$Ship.hp += values[0]
	else:
		$Ship2.hp += values[0]
