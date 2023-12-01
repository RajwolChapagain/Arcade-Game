extends Control

@export var ships_sprites : Array
var left_pointer = 1:
	get:
		return left_pointer
	set(value):
		left_pointer = clamp(value, 0, ships_sprites.size() - 1)
var right_pointer = 1:
	get:
		return right_pointer
	set(value):
		right_pointer = clamp(value, 0, ships_sprites.size() - 1)

func _ready():
	set_sprite(1, ships_sprites[0])
	set_sprite(2, ships_sprites[2])	
	pass #▶Initialize sprite based on pointers

func _input(event):
	if event.is_action_pressed("p1_left"):
		left_pointer -= 1
	if event.is_action_pressed("p1_right"):
		left_pointer += 1
	if event.is_action_pressed("p2_left"):	
		right_pointer -= 1
	if event.is_action_pressed("p2_right"):
		right_pointer += 1
	
func set_sprite(player, sprite : Texture2D):
	var ship_sprite = $Selection/LeftItems/LeftShip if player == 1 else $Selection/RightItems/RightShip
	ship_sprite.texture = sprite
