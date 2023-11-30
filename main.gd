extends Node2D

func _ready():
	$Ship.bullet_fired.connect(on_player1_fired_bullet)
	$Ship2.bullet_fired.connect(on_player2_fired_bullet)
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
	$Ship2.owner_player = 2
	
	var offset = 80
	$Spawner.set_path_points(Vector2(-2000 - offset, -1500 - offset), Vector2(2000 + offset, -1500 - offset), Vector2(2000 + offset, 1500 + offset), Vector2(-2000 - offset, 1500 + offset))

#	randomize()
#	var randX = randi_range(0, 100)
#	var randY = randi_range(-1000, 1000)
#	$Ship.position += Vector2(randX, randY)
#	randX = randi_range(0, -1000)
#	randY = randi_range(-1000, 1000)
#	$Ship2.position += Vector2(randX, randY)
	
func _physics_process(_delta):
	update_bullet_ring_position()
	
func on_player1_fired_bullet(bullet_scene, direction, location):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = location
	bullet.set_direction(direction) 
	bullet.owner_player = 1
	add_child(bullet)

func on_player2_fired_bullet(bullet_scene, direction, location):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = location
	bullet.set_direction(direction) 
	bullet.owner_player = 2	
	add_child(bullet)
	
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
	
func on_player1_bullet_ring_activated(bullet_ring_scene, bullet_layer_mask, shared_bullet_layer):
	var bullet_ring = bullet_ring_scene.instantiate()
	bullet_ring.global_position = $Ship.global_position
	bullet_ring.set_bullets_layer(shared_bullet_layer)
	bullet_ring.set_bullets_layer($Ship.ONLY_SHIP1_BULLET_LAYER)	
	bullet_ring.set_bullets_layer_mask(bullet_layer_mask)
	bullet_ring.owner_player = 1
	bullet_ring.destroyed.connect($Ship.on_bullet_ring_destroyed)	
	bullet_ring.radius += 100 * $Ship.bullet_rings_owned		
	$Ship.bullet_rings_owned += 1
	add_child(bullet_ring)

func on_player2_bullet_ring_activated(bullet_ring_scene, bullet_layer_mask, shared_bullet_layer):
	var bullet_ring = bullet_ring_scene.instantiate()
	bullet_ring.global_position = $Ship2.global_position
	bullet_ring.set_bullets_layer($Ship2.ONLY_SHIP2_BULLET_LAYER)	
	bullet_ring.set_bullets_layer_mask(bullet_layer_mask)
	bullet_ring.set_bullets_layer_mask(shared_bullet_layer)
	bullet_ring.owner_player = 2
	bullet_ring.destroyed.connect($Ship2.on_bullet_ring_destroyed)
	bullet_ring.radius += 100 * $Ship2.bullet_rings_owned
	$Ship2.bullet_rings_owned += 1	
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
		$Ship.super_percentage += values[0]
	elif player == 2:
		$Ship2.super_percentage +=  values[0]
	
func _on_hp_boost_collected(player, values):
	if player == 1:
		$Ship.hp += values[0]
	elif player == 2:
		$Ship2.hp += values[0]

func _on_accleration_boost_collected(player, values):
	if player == 1:
		$Ship.THRUST_FORCE += values[0]
		await get_tree().create_timer(values[1]).timeout
		if get_node_or_null("Ship") != null: #Can return null and crash if ship dies before timeout
			$Ship.THRUST_FORCE -= values[0]
	elif player == 2:
		$Ship2.THRUST_FORCE += values[0]
		await get_tree().create_timer(values[1]).timeout
		if get_node_or_null("Ship2") != null:
			$Ship.THRUST_FORCE -= values[0]
		$Ship2.THRUST_FORCE -= values[0]

func _on_ufo_fired_bullet(bullet_scene, pos, dir, layers, layer_masks):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = pos
	bullet.set_direction(dir)
	
	for layer in layers:
		bullet.set_collision_layer_value(layer, true)

	for mask in layer_masks:
		bullet.set_collision_mask_value(mask, true)
		
	bullet.owner_player = 3
	add_child(bullet)
		
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
		
