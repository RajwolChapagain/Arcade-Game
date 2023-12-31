extends Node2D

@export var ships : Array[PackedScene] ##Has to be in the same order as ship_sprites in Main Menu
var p1_ship_index = 0
var p2_ship_index = 0
var round_is_over = false
var round_number = 1
var rounds_won_by_p1 = 0
var rounds_won_by_p2 = 0

func _ready():
	var offset = 80
	$Spawner.set_path_points(Vector2(-2000 - offset, -1500 - offset), Vector2(2000 + offset, -1500 - offset), Vector2(2000 + offset, 1500 + offset), Vector2(-2000 - offset, 1500 + offset))
	
func _physics_process(delta):
	$HUD.set_round_time(round($RoundTimer.time_left))
	
func on_player1_fired_bullet(bullet_scene, damage, direction, location, owner_player):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = location
	bullet.set_direction(direction) 
	bullet.owner_player = 1
	bullet.DAMAGE = damage
	bullet.owner_player = owner_player
	bullet.bullet_did_damage.connect(on_bullet_did_damage)
	add_child(bullet)
	shake_camera(0.1, 100)

func on_player2_fired_bullet(bullet_scene, damage, direction, location, owner_player):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = location
	bullet.set_direction(direction) 
	bullet.owner_player = 2	
	bullet.DAMAGE = damage
	bullet.owner_player = owner_player
	add_child(bullet)
	shake_camera(0.1, 100)	

func on_player1_fired_super(super_duration):
	shake_camera(0.15, super_duration * 1000)

func on_player2_fired_super(super_duration):
	shake_camera(0.15, super_duration * 1000)
	
func on_bullet_did_damage(damaging_player, damage_amount):
	if damaging_player == 1 and get_node_or_null("Player1") != null:
		$Player1.super_percentage += damage_amount / 2
	elif damaging_player == 2 and get_node_or_null("Player2") != null:
		$Player2.super_percentage += damage_amount / 2
		
func on_player1_hp_changed(new_hp):
	$HUD.set_p1_health(new_hp)

func on_player2_hp_changed(new_hp):
	$HUD.set_p2_health(new_hp)
	
func on_player1_super_percentage_changed(new_super_percentage):
	$HUD.update_p1_super_bar(new_super_percentage)

func on_player2_super_percentage_changed(new_super_percentage):
	$HUD.update_p2_super_bar(new_super_percentage)
	
func on_player1_hit(_damage):
	shake_camera(0.2, 200)

func on_player2_hit(_damage):
	shake_camera(0.2, 200)
	
func on_player1_died():
	delete_bullet_rings(1)	
	if not round_is_over:
		on_round_over(2)

func on_player2_died():
	delete_bullet_rings(2)	
	if not round_is_over:
		on_round_over(1)

func on_round_over(winner):
	round_is_over = true
	$RoundTimer.paused = true
	if winner == 1:
		$HUD.set_p2_health(0)
		rounds_won_by_p1 += 1
	elif winner == 2:
		$HUD.set_p1_health(0)
		rounds_won_by_p2 += 1
	$HUD.announce_winner(winner)
	await get_tree().create_timer(5).timeout
	$HUD.hide_announcement_text()

	if rounds_won_by_p1 == 2 or rounds_won_by_p2 == 2:
		get_tree().reload_current_scene()
	else:
		start_next_round()
	
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
	p1_ship_index = p1_ship
	p2_ship_index = p2_ship
	instantiate_ships()

func instantiate_ships():
	var player1_ship = ships[p1_ship_index].instantiate()
	player1_ship.name = "Player1"
	add_child(player1_ship)
	var player2_ship = ships[p2_ship_index].instantiate()
	player2_ship.name = "Player2"
	add_child(player2_ship)
	initialize_players(player1_ship, player2_ship)
	$MainMenu.visible = false
	$HUD.visible = true
	$Spawner.start_spawn_timer()
	$RoundTimer.start()

func initialize_players(p1_ship_node, p2_ship_node):
	p1_ship_node.bullet_fired.connect(on_player1_fired_bullet)
	p2_ship_node.bullet_fired.connect(on_player2_fired_bullet)
	p1_ship_node.super_fired.connect(on_player1_fired_super)
	p2_ship_node.super_fired.connect(on_player2_fired_super)	
	p1_ship_node.hp_changed.connect(on_player1_hp_changed)
	p2_ship_node.hp_changed.connect(on_player2_hp_changed)
	p1_ship_node.super_percentage_changed.connect(on_player1_super_percentage_changed)	
	p2_ship_node.super_percentage_changed.connect(on_player2_super_percentage_changed)
	p1_ship_node.player_died.connect(on_player1_died)
	p2_ship_node.player_died.connect(on_player2_died)
	p1_ship_node.hit.connect(on_player1_hit)
	p2_ship_node.hit.connect(on_player2_hit)
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

func shake_camera(intensity: float, duration: float):
	intensity = clampf(intensity, 0, 1)
	var max_distance = 100
	
	var start_time = Time.get_ticks_msec()
	
	while Time.get_ticks_msec() - start_time  < duration:
		$Camera2D.offset = Vector2(max_distance * intensity * randf_range(-1, 1), max_distance * intensity * randf_range(-1, 1))
		
		if is_inside_tree():
			await get_tree().process_frame
	
	$Camera2D.offset = Vector2.ZERO
	
func start_next_round():
	round_number += 1
	get_tree().call_group("ship", "free")
	get_tree().call_group("spawned_objects", "queue_free")
	get_tree().call_group("bullet", "queue_free")
	instantiate_ships()
	round_is_over = false
	$RoundTimer.paused = false
	$RoundTimer.start()

func _on_round_timer_timeout():
	$HUD.show_announcement_text("TIME OVER")
	get_tree().paused = true
	
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	
	var winner = 1 if ($Player1.hp > $Player2.hp) else 2
	
	if winner == 1:
		tween.tween_property($Player1, "hp", $Player1.hp - $Player2.hp, 1.5)
		tween.tween_property($Player2, "hp", 0, 1.5)
	elif winner == 2:
		tween.tween_property($Player2, "hp", $Player2.hp - $Player1.hp, 1.5)
		tween.tween_property($Player1, "hp", 0, 1.5)
	
	await get_tree().create_timer(1.5, true).timeout
	on_round_over(winner)
	
	if winner == 1:
		$Player2.queue_free()
	if winner == 2:
		$Player1.queue_free()
		
	get_tree().paused = false	
		
	
	
	
	
