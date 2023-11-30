extends Control

@export var ships : Array
var left_pointer = 1
var right_pointer = 1

func _ready():
	pass #▶Initialize sprite based on pointers

func _input(event):
	if event.is_action_pressed("p1_left"):
		$Selection/LeftItems/LeftLeftArrow.visible = false
	if event.is_action_pressed("p1_right"):
		$Selection/LeftItems/LeftLeftArrow.visible = false
	if event.is_action_pressed("p1_up"):
		$Selection/LeftItems/LeftLeftArrow.visible = false
	if event.is_action_pressed("p1_down"):
		$Selection/LeftItems/LeftLeftArrow.visible = false
