extends Node2D

@export var ships : Array[PackedScene] ##Has to be in the same order as ship_sprites in Main Menu

func _ready():
	var offset = 80
	$Spawner.set_path_points(Vector2(-2000 - offset, -1500 - offset), Vector2(2000 + offset, -1500 - offset), Vector2(2000 + offset, 1500 + offset), Vector2(-2000 - offset, 1500 + offset))
#	randomize()
#	var randX = randi_range(0, 100)
#	var randY = randi_range(-1000, 1000)
#	$Player1.position += Vector2(randX, randY)
#	randX = randi_range(0, -1000)
#	randY = randi_range(-1000, 1000)
#	$Player2.position += Vector2(randX, randY)
	
func on_player1_fired_bullet(bullet_scene, damage, direction, location, owner_player):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = location
	bullet.set_direction(direction) 
	bullet.owner_player = 1
	bullet.DAMAGE = damage
	bullet.owner_player = owner_player
	add_child(bullet)

func on_player2_fired_bullet(bullet_scene, damage, direction, location, owner_player):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = location
	bullet.set_direction(direction) 
	bullet.owner_player = 2	
	bullet.DAMAGE = damage
	bullet.owner_player = owner_player
	add_child(bullet)
	
func on_player1_hit(damage):
	if get_node_or_null("Player2") != null: #Can happen if bullet hits player after other player has died
		$Player2.super_percentage += damage / 2
	
func on_player2_hit(damage):
	if get_node_or_null("Player1") != null:
		$Player1.super_percentage += damage / 2

func on_player1_hp_changed(new_hp):
	$HUD.set_p1_health(new_hp)

func on_player2_hp_changed(new_hp):
	$HUD.set_p2_health(new_hp)
	
func on_player1_super_percentage_changed(new_super_percentage):
	$HUD.update_p1_super_bar(new_super_percentage)

func on_player2_super_percentage_changed(new_super_percentage):
	$HUD.update_p2_super_bar(new_super_percentage)
	
func on_player1_died():
	on_game_over(2)

func on_player2_died():
	on_game_over(1)

func on_game_over(winner):
	if winner == 1:
		$HUD.set_p1_health(0)
		delete_bullet_rings(1)
	elif winner == 2:
		$HUD.set_p2_health(0)
		delete_bullet_rings(1)
		
	$HUD.announce_winner(winner)
	await get_tree().create_timer(5).timeout
	get_tree().reload_current_scene()
	
func _on_spawner_object_spawned(object):
	if object.is_in_group("super_boost"):
		object.collected.connect(_on_super_boost_collected)
	elif object.is_in_group("hp_boost"):
		object.collected.connect(_on_hp_boost_collected)
	elif object.is_in_group("acceleration_boost"):
		object.collected.connect(_on_accleration_boost_collected)
	elif object.is_in_group("ufo"):
		object.bullet_fired.connect(_on_ufo_fired_bullet)
		
func _on_super_boost_collected(player, values):
	if player == 1:
		$Player1.super_percentage += values[0]
	elif player == 2:
		$Player2.super_percentage +=  values[0]
	
func _on_hp_boost_collected(player, values):
	if player == 1:
		$Player1.hp += values[0]
	elif player == 2:
		$Player2.hp += values[0]

func _on_accleration_boost_collected(player, values):
	if player == 1:
		$Player1.THRUST_FORCE += values[0]
		await get_tree().create_timer(values[1]).timeout
		if get_node_or_null("Player1") != null: #Can return null and crash if Player1 dies before timeout
			$Player1.THRUST_FORCE -= values[0]
	elif player == 2:
		$Player2.THRUST_FORCE += values[0]
		await get_tree().create_timer(values[1]).timeout
		if get_node_or_null("Player2") != null:
			$Player1.THRUST_FORCE -= values[0]
		$Player2.THRUST_FORCE -= values[0]

func _on_ufo_fired_bullet(bullet_scene, pos, dir):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = pos
	bullet.set_direction(dir)		
	bullet.owner_player = 3
	add_child(bullet)

func delete_bullet_rings(player):
	for ring in get_tree().get_nodes_in_group("bullet_ring"):
		if ring.owner_player == player:
			ring.queue_free()
		

func _on_main_menu_both_players_ready(p1_ship, p2_ship):
	var player1_ship = ships[p1_ship].instantiate()
	player1_ship.name = "Player1"
	add_child(player1_ship)
	var player2_ship = ships[p2_ship].instantiate()
	player2_ship.name = "Player2"
	add_child(player2_ship)
	initialize_players(player1_ship, player2_ship)
	$MainMenu.visible = false
	$HUD.visible = true
	$Spawner.start_spawn_timer()

func initialize_players(p1_ship_node, p2_ship_node):
	p1_ship_node.bullet_fired.connect(on_player1_fired_bullet)
	p2_ship_node.bullet_fired.connect(on_player2_fired_bullet)
	p1_ship_node.hit.connect(on_player1_hit)
	p2_ship_node.hit.connect(on_player2_hit)
	p1_ship_node.hp_changed.connect(on_player1_hp_changed)
	p2_ship_node.hp_changed.connect(on_player2_hp_changed)
	p1_ship_node.super_percentage_changed.connect(on_player1_super_percentage_changed)	
	p2_ship_node.super_percentage_changed.connect(on_player2_super_percentage_changed)
	p1_ship_node.player_died.connect(on_player1_died)
	p2_ship_node.player_died.connect(on_player2_died)
	p2_ship_node.owner_player = 2
	p1_ship_node.global_position = Vector2($Camera2D.get_screen_center_position().x - 1000, $Camera2D.get_screen_center_position().y)
	p2_ship_node.global_position = Vector2($Camera2D.get_screen_center_position().x + 1000, $Camera2D.get_screen_center_position().y)
	p2_ship_node.rotation += PI
	
	p2_ship_node.LEFT_STRING = "p2_left"
	p2_ship_node.RIGHT_STRING = "p2_right"
	p2_ship_node.UP_STRING = "p2_up"
	p2_ship_node.DOWN_STRING = "p2_down"
	p2_ship_node.FIRE_STRING = "p2_fire"
	p2_ship_node.SUPER_STRING = "p2_super"
	p2_ship_node.SHIELD_STRING = "p2_shield"

	$HUD.initialize_max_hp_bar(1, p1_ship_node.max_hp)
	$HUD.initialize_max_hp_bar(2, p2_ship_node.max_hp)
	
