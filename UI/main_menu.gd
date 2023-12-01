extends Control

@export var ships : Array
var left_pointer = 1:
	get:
		return left_pointer
	set(value):
		left_pointer = clamp(value, 0, ships.size() - 1)
var right_pointer = 1:
	get:
		return right_pointer
	set(value):
		right_pointer = clamp(value, 0, ships.size() - 1)

func _ready():
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
	
