extends Control

@export var ships_sprites : Array
@export var ship_stats : Array ##Must follow the same order as ships_sprites

var left_pointer = 1:
	get:
		return left_pointer
	set(value):
		left_pointer = clamp(value, 0, ships_sprites.size() - 1)
		set_sprite(1, ships_sprites[left_pointer])
		$P1Stats.tween_to_stats(ship_stats[left_pointer])
var right_pointer = 1:
	get:
		return right_pointer
	set(value):
		right_pointer = clamp(value, 0, ships_sprites.size() - 1)
		set_sprite(2, ships_sprites[right_pointer])		
		$P2Stats.tween_to_stats(ship_stats[right_pointer])
		
var player1_inserted_coin = false
var player2_inserted_coin = false
var player1_ready = false
var player2_ready = false
var game_started = false

signal both_players_ready(p1_ship, p2_ship)

func _input(event):
	if game_started:
		return
		
	if event.is_action_pressed("p1_left") or event.is_action_pressed("p1_ui_left"):
		if player1_inserted_coin and !player1_ready:
			left_pointer -= 1
	if event.is_action_pressed("p1_right") or event.is_action_pressed("p1_ui_right"):
		if player1_inserted_coin and !player1_ready:
			left_pointer += 1
	if event.is_action_pressed("p2_left") or event.is_action_pressed("p2_ui_left"):	
		if player2_inserted_coin and !player2_ready:
			right_pointer -= 1
	if event.is_action_pressed("p2_right") or event.is_action_pressed("p2_ui_right"):
		if player2_inserted_coin and !player2_ready:
			right_pointer += 1
	
	if event.is_action_pressed("p1_insert_coin"):
		on_player_insert_coin(1)
	if event.is_action_pressed("p2_insert_coin"):
		on_player_insert_coin(2)
	
	if event.is_action_pressed("p1_fire"):
		if player1_inserted_coin:
			make_player_ready(1)
	if event.is_action_pressed("p2_fire"):
		if player2_inserted_coin:
			make_player_ready(2)
		
func set_sprite(player, sprite : Texture2D):
	var ship_sprite = $Selection/LeftItems/LeftShip if player == 1 else $Selection/RightItems/RightShip
	ship_sprite.texture = sprite

func on_player_insert_coin(player):
	if player == 1:
		player1_inserted_coin = true
		player1_ready = false
	elif player == 2:
		player2_inserted_coin = true
		player2_ready = false
		
	set_prompt(player, "Select Ship")
	
func make_player_ready(player):
	if player == 1:
		player1_ready = true
		if player2_ready:
			start_game()
	elif player == 2:
		player2_ready = true
		if player1_ready:
			start_game()
	set_prompt(player, "Ready!")
	
func set_prompt(player, text):
	var label = $Prompt/Label if player == 1 else $Prompt/Label2
	label.text = text

func start_game():
	both_players_ready.emit(left_pointer, right_pointer)
	game_started = true
