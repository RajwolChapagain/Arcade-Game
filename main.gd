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
	$Ship.bullet_ring_activated.connect(on_player1_bullet_ring_activated)
	$Ship2.bullet_ring_activated.connect(on_player2_bullet_ring_activated)
	
	var offset = 80
	$Spawner.set_path_points(Vector2(-2000 - offset, -1500 - offset), Vector2(2000 + offset, -1500 - offset), Vector2(2000 + offset, 1500 + offset), Vector2(-2000 - offset, 1500 + offset))

	randomize()
	var randX = randi_range(0, 100)
	var randY = randi_range(-1000, 1000)
	$Ship.position += Vector2(randX, randY)
	randX = randi_range(0, -1000)
	randY = randi_range(-1000, 1000)
	$Ship2.position += Vector2(randX, randY)
	
func _physics_process(_delta):
	update_bullet_ring_position()
	
func on_player_fired_bullet(bullet_scene, direction, location, bullet_layer):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = location
	add_child(bullet)
	bullet.set_direction(direction) 
	bullet.set_collision_layer(bullet_layer)
	bullet.set_collision_mask(bullet_layer)

func on_player1_hit(damage):
	if get_node_or_null("Ship2") != null: #Can happen if bullet hits player after other player has died
		$Ship2.super_percentage += damage / 2
	
func on_player2_hit(damage):
	if get_node_or_null("Ship") != null:
		$Ship.super_percentage += damage / 2

func on_player1_hp_changed(new_hp):
	$HUD.set_p1_health(new_hp)

func on_player2_hp_changed(new_hp):
	$HUD.set_p2_health(new_hp)
	
func on_player1_super_percentage_changed(new_super_percentage):
	$HUD.update_p1_super_bar(new_super_percentage)

func on_player2_super_percentage_changed(new_super_percentage):
	$HUD.update_p2_super_bar(new_super_percentage)
	
func on_player1_bullet_ring_activated(bullet_ring_scene, bullet_layer):
	var bullet_ring = bullet_ring_scene.instantiate()
	bullet_ring.global_position = $Ship.global_position
	bullet_ring.set_bullets_layer(bullet_layer)
	bullet_ring.owner_player = 1
	add_child(bullet_ring)

func on_player2_bullet_ring_activated(bullet_ring_scene, bullet_layer):
	var bullet_ring = bullet_ring_scene.instantiate()
	bullet_ring.global_position = $Ship2.global_position
	bullet_ring.set_bullets_layer(bullet_layer)
	bullet_ring.owner_player = 2
	add_child(bullet_ring)
	
func on_player1_died():
	$HUD.set_p1_health(0)
	delete_bullet_rings(1)
	on_game_over("Player2")

func on_player2_died():
	$HUD.set_p2_health(0)
	delete_bullet_rings(2)
	on_game_over("Player1")

func on_game_over(winner):
	print(winner + " wins!")

func _on_spawner_powerup_spawned(powerup):
	if powerup.is_in_group("super_boost"):
		powerup.collected.connect(_on_super_boost_collected)
	elif powerup.is_in_group("hp_boost"):
		powerup.collected.connect(_on_hp_boost_collected)
	elif powerup.is_in_group("acceleration_boost"):
		powerup.collected.connect(_on_accleration_boost_collected)
	
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

func _on_accleration_boost_collected(player, values):
	if player == 1:
		$Ship.THRUST_FORCE += values[0]
		await get_tree().create_timer(values[1]).timeout
		$Ship.THRUST_FORCE -= values[0]
	else:
		$Ship2.THRUST_FORCE += values[0]
		await get_tree().create_timer(values[1]).timeout
		$Ship2.THRUST_FORCE -= values[0]

func update_bullet_ring_position():
	for ring in get_tree().get_nodes_in_group("bullet_ring"):
		if ring.owner_player == 1:
			if get_node_or_null("Ship") != null:
				ring.global_position = $Ship.position
		else:
			if get_node_or_null("Ship2") != null:
				ring.global_position = $Ship2.position

func delete_bullet_rings(player):
	for ring in get_tree().get_nodes_in_group("bullet_ring"):
		if ring.owner_player == player:
			ring.queue_free()
		
