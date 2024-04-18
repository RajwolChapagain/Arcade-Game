extends Node2D

@export var playtesting = false
@export var ships : Array[PackedScene] ##Has to be in the same order as ship_sprites in Main Menu

var hit_particles_material = preload("res://ship/materials/hit_particles.tres")
var explosion_particles_material = preload("res://ship/materials/explosion_particles.tres")

var materials = [hit_particles_material, explosion_particles_material]

var p1_ship_index = 0
var p2_ship_index = 0
var round_is_over = false
var round_number = 1
var rounds_won_by_p1 = 0
var rounds_won_by_p2 = 0

#Playtesting variables
var total_bullets_fired_p1 = 0
var total_bullets_fired_p2 = 0
var total_bullets_missed_p1 = 0
var total_bullets_missed_p2 = 0
var num_shield_used_p1 = 0
var num_shield_used_p2 = 0
var num_alternative_shield_used_p1 = 0
var num_alternative_shield_used_p2 = 0
var num_super_fired_p1 = 0
var num_super_fired_p2 = 0
var num_alternative_super_fired_p1 = 0
var num_alternative_super_fired_p2 = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _physics_process(_delta):
	if not $RoundTimer.is_stopped():
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
	if playtesting:
		total_bullets_fired_p1 += 1
		bullet.bullet_exited_screen.connect(on_bullet_exit_screen)
	
func on_player2_fired_bullet(bullet_scene, damage, direction, location, owner_player):
	var bullet = bullet_scene.instantiate()
	bullet.global_position = location
	bullet.set_direction(direction) 
	bullet.owner_player = 2	
	bullet.DAMAGE = damage
	bullet.owner_player = owner_player
	add_child(bullet)
	shake_camera(0.1, 100)	
	if playtesting:
		total_bullets_fired_p2 += 1
		bullet.bullet_exited_screen.connect(on_bullet_exit_screen)		

func on_player1_fired_super(super_duration):
	shake_camera(0.15, super_duration * 1000)
	if playtesting:
		num_super_fired_p1 += 1

func on_player2_fired_super(super_duration):
	shake_camera(0.15, super_duration * 1000)
	if playtesting:
		num_super_fired_p2 += 1
		
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
	
func on_player1_hit(_damage, hit_particles_scene, global_pos):
	shake_camera(0.2, 200)
	var hit_particles = hit_particles_scene.instantiate()
	hit_particles.global_position = global_pos
	add_child(hit_particles)
	hit_particles.emitting = true
	
func on_player2_hit(_damage, hit_particles_scene, global_pos):
	shake_camera(0.2, 200)
	var hit_particles = hit_particles_scene.instantiate()
	hit_particles.global_position = global_pos
	add_child(hit_particles)
	hit_particles.emitting = true
	
func on_player1_died(explosion_scene, global_pos):
	delete_bullet_rings(1)	
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_pos
	add_child(explosion)
	if not round_is_over:
		on_round_over(2)

func on_player2_died(explosion_scene, global_pos):
	delete_bullet_rings(2)	
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_pos
	add_child(explosion)
	if not round_is_over:
		on_round_over(1)

func on_round_over(winner):
	round_is_over = true
	$RoundTimer.paused = true
	if winner == 1:
		$HUD.set_p2_health(0)
		rounds_won_by_p1 += 1
		$HUD.indicate_round_won(winner, rounds_won_by_p1)
	elif winner == 2:
		$HUD.set_p1_health(0)
		rounds_won_by_p2 += 1
		$HUD.indicate_round_won(winner, rounds_won_by_p2)		
	$HUD.announce_winner(winner)
	
	if playtesting:
		save_end_of_round_playtesting_data()
	
	if rounds_won_by_p1 == 2 or rounds_won_by_p2 == 2:
		fade_music_out()
		
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
		$Player2.THRUST_FORCE -= values[0] #FIXME: These kinds of code create crashes when the player is freed after game over but it still tries to execute after await timeout is over

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
	cache_particles(materials)
	$HUD.visible = true
	$HUD.get_node("StartCountdownLabel").visible = true
	$Spawner.start_spawn_timer()
	$HUD.get_node("StartCountdownLabel/Countdown").play("countdown")
	$HUD/SuperBar.value = 100
	$HUD/SuperBar2.value = 100
	get_tree().paused = true
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
	p1_ship_node.global_position = Vector2($Camera2D.get_screen_center_position().x - 250, $Camera2D.get_screen_center_position().y)
	p2_ship_node.global_position = Vector2($Camera2D.get_screen_center_position().x + 250, $Camera2D.get_screen_center_position().y)
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

	if playtesting:
		p1_ship_node.shield_activated.connect(on_shield_activated)
		p1_ship_node.bullet_ring_activated.connect(on_bullet_ring_activated)
		p1_ship_node.alternative_super_fired.connect(on_alternative_super_fired)
		
		p2_ship_node.shield_activated.connect(on_shield_activated)
		p2_ship_node.bullet_ring_activated.connect(on_bullet_ring_activated)
		p2_ship_node.alternative_super_fired.connect(on_alternative_super_fired)
		
func shake_camera(intensity: float, duration: float):
	intensity = clampf(intensity, 0, 1)
	var max_distance = 50
	
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
		$Player2.die()
	if winner == 2:
		$Player1.die()
		
	get_tree().paused = false	
		
func on_bullet_exit_screen(owner_player):
	if owner_player == 1:
		total_bullets_missed_p1 += 1
	elif owner_player == 2:
		total_bullets_missed_p2 += 1
	
func on_shield_activated(owner_player):
	if owner_player == 1:
		num_shield_used_p1 += 1
	elif owner_player == 2:
		num_shield_used_p2 += 1
		
func on_bullet_ring_activated(owner_player):
	if owner_player == 1:
		num_alternative_shield_used_p1 += 1
	if owner_player == 2:
		num_alternative_shield_used_p2 += 1
		
func on_alternative_super_fired(owner_player):
	if owner_player == 1:
		num_alternative_super_fired_p1  += 1
	elif owner_player == 2:
		num_alternative_super_fired_p2 += 1
	
func save_end_of_round_playtesting_data():
		DataWriter.save_data("=============================================================================================================")
		DataWriter.save_data("Round Length (seconds): " + str(int(90 - $RoundTimer.time_left)))
		DataWriter.save_data("")
		
		DataWriter.save_data("Total bullets fired by P1: " + str(total_bullets_fired_p1))
		DataWriter.save_data("Total bullets missed by P1: " + str(total_bullets_missed_p1))
		if total_bullets_fired_p1 != 0:
			DataWriter.save_data("P1 Hit Rate: " + str((total_bullets_fired_p1 - total_bullets_missed_p1) * 100.0 / total_bullets_fired_p1) + "%")
		else:
			DataWriter.save_data("P1 didn't fire any shots!")
		DataWriter.save_data("")
		
		DataWriter.save_data("Total bullets fired by P2: " + str(total_bullets_fired_p2))
		DataWriter.save_data("Total bullets missed by P2: " + str(total_bullets_missed_p2))
		if total_bullets_fired_p2 != 0:
			DataWriter.save_data("P2 Hit Rate: " + str((total_bullets_fired_p2 - total_bullets_missed_p2) * 100.0 / total_bullets_fired_p2) + "%")
		else:
			DataWriter.save_data("P2 didn't fire any shots!")
		DataWriter.save_data("")
		
		DataWriter.save_data("Number of supers fired by P1: " + str(num_super_fired_p1))
		DataWriter.save_data("Number of supers fired by P2: " + str(num_super_fired_p2))	
		DataWriter.save_data("")
		
		DataWriter.save_data("Number of alternative supers fired by P1: " + str(num_alternative_super_fired_p1))
		DataWriter.save_data("Number of alternative supers fired by P2: " + str(num_alternative_super_fired_p2))
		DataWriter.save_data("")
		
		DataWriter.save_data("Number of shields used by P1: " + str(num_shield_used_p1))
		DataWriter.save_data("Number of shields used by P2: " + str(num_shield_used_p2))
		DataWriter.save_data("")
		
		DataWriter.save_data("Number of alternative shields used by P1: " + str(num_alternative_shield_used_p1))
		DataWriter.save_data("Number of alternative shields used by P2: " + str(num_alternative_shield_used_p2))
		DataWriter.save_data("")
		

		total_bullets_fired_p1 = 0
		total_bullets_fired_p2 = 0
		total_bullets_missed_p1 = 0
		total_bullets_missed_p2 = 0
		num_super_fired_p1 = 0
		num_super_fired_p2 = 0
		num_alternative_super_fired_p1 = 0
		num_alternative_super_fired_p2 = 0
		num_shield_used_p1 = 0
		num_shield_used_p2 = 0
		num_alternative_shield_used_p1 = 0
		num_alternative_shield_used_p2 = 0


func _on_music_finished():
	await get_tree().create_timer(5).timeout
	$Music.play()

func fade_music_out():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Music, "volume_db", -80, 4).set_ease(Tween.EASE_IN)
	tween.tween_property($Music, "pitch_scale", 0.5, 2).set_ease(Tween.EASE_IN)

func _on_start_timer_timeout():
	get_tree().paused = false

func cache_particles(materials):
	for mat in materials:
		var particles_instance = GPUParticles2D.new()
		particles_instance.set_process_material(mat)
		particles_instance.set_one_shot(true)
		particles_instance.set_modulate(Color(1,1,1,0))
		particles_instance.set_emitting(true)
		add_child(particles_instance)
